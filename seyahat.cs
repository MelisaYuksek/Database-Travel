using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Travel_App
{
    public partial class adminUsers : Form
    {
        public adminUsers()
        {
            InitializeComponent();
        }



        NpgsqlConnection baglanti = new NpgsqlConnection("server=localHost; port=5432; Database=seyahatproje; " +
            "user ID=postgres; password=5847");

        private void LoadAdminList()
        {
            string sorgu = "SELECT * FROM adminuser";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            dgvAdmins.DataSource = ds.Tables[0];
        }

        private void adminlist_Click(object sender, EventArgs e)
        {
            string sorgu = "select * from adminuser";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds= new DataSet();
            da.Fill(ds);
            dgvAdmins.DataSource = ds.Tables[0];
        

        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            baglanti.Open();

            // Dış anahtar gereksinimini karşılamak için doğru userid'yi kullanıyoruz
            // Diyelim ki, users tablosundaki son eklenen userid'yi alacağız:
            string getUserIdQuery = "SELECT MAX(userid) FROM public.users";  // Veya uygun bir sorgu
            NpgsqlCommand komutGetUserId = new NpgsqlCommand(getUserIdQuery, baglanti);
            int userId = Convert.ToInt32(komutGetUserId.ExecuteScalar());

            NpgsqlCommand komut1 = new NpgsqlCommand("INSERT INTO public.adminuser (userid, name, surname, email, password, phoneno, adminprivileges, permissionlevel) " +
                "VALUES (@p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)", baglanti);

            komut1.Parameters.AddWithValue("@p1", userId);  // Burada doğru userid'yi kullanıyoruz
            komut1.Parameters.AddWithValue("@p2", txtName.Text);
            komut1.Parameters.AddWithValue("@p3", txtSurname.Text);
            komut1.Parameters.AddWithValue("@p4", txtEmail.Text);
            komut1.Parameters.AddWithValue("@p5", txtPassword.Text);
            komut1.Parameters.AddWithValue("@p6", txtPhoneno.Text);
            komut1.Parameters.AddWithValue("@p7", up_combo.Text);
            komut1.Parameters.AddWithValue("@p8", int.Parse(pl_combo.Text));

            komut1.ExecuteNonQuery();
            baglanti.Close();
            MessageBox.Show("Admin user added successfully.");

            LoadAdminList();
        }


        private void btnDelete_Click(object sender, EventArgs e)
        {
            // Ensure a row is selected before attempting to delete
            if (dgvAdmins.SelectedRows.Count > 0)
            {
                // Get the userid of the selected row
                int selectedRowIndex = dgvAdmins.SelectedRows[0].Index;
                int userId = Convert.ToInt32(dgvAdmins.Rows[selectedRowIndex].Cells["userid"].Value); // Ensure the column name is correct

                // Open connection to the database
                baglanti.Open();

                // Create DELETE query with the userid parameter
                NpgsqlCommand komut2 = new NpgsqlCommand("DELETE FROM public.adminuser WHERE userid = @p1", baglanti);
                komut2.Parameters.AddWithValue("@p1", userId); // Pass the userid of the selected admin

                // Execute the delete command
                komut2.ExecuteNonQuery();
                baglanti.Close();

                // Display a message box to confirm deletion
                MessageBox.Show("Deleted successfully.", "Attention", MessageBoxButtons.OK, MessageBoxIcon.Stop);

                // Refresh the DataGridView to reflect the changes
                LoadAdminList();
            }
            else
            {
                MessageBox.Show("Please select a row to delete.");
            }
        }


        private void btnUpdate_Click(object sender, EventArgs e)
        {// Ensure a row is selected before attempting to update
            if (dgvAdmins.SelectedRows.Count > 0)
            {
                // Get the userid of the selected row
                int selectedRowIndex = dgvAdmins.SelectedRows[0].Index;
                int userId = Convert.ToInt32(dgvAdmins.Rows[selectedRowIndex].Cells["userid"].Value); // Ensure the column name is correct

                // Try parsing the permission level
                int permissionLevel;
                if (!int.TryParse(pl_combo.Text, out permissionLevel))
                {
                    MessageBox.Show("Please enter a valid number for permission level.");
                    return;
                }

                // Open connection to the database
                baglanti.Open();

                // Create UPDATE query with the userid and new values
                NpgsqlCommand komut3 = new NpgsqlCommand(
                    "UPDATE public.adminuser SET name = @p1, surname = @p2, email = @p3, password = @p4, phoneno = @p5, adminprivileges = @p6, permissionlevel = @p7 WHERE userid = @p8",
                    baglanti
                );
                komut3.Parameters.AddWithValue("@p1", txtName.Text);
                komut3.Parameters.AddWithValue("@p2", txtSurname.Text);
                komut3.Parameters.AddWithValue("@p3", txtEmail.Text);
                komut3.Parameters.AddWithValue("@p4", txtPassword.Text);
                komut3.Parameters.AddWithValue("@p5", txtPhoneno.Text);
                komut3.Parameters.AddWithValue("@p6", up_combo.Text);
                komut3.Parameters.AddWithValue("@p7", permissionLevel); // Use the parsed permission level
                komut3.Parameters.AddWithValue("@p8", userId); // Use the userId to identify which admin user to update

                // Execute the update command
                komut3.ExecuteNonQuery();
                baglanti.Close();

                // Display a message box to confirm the update
                MessageBox.Show("Updated successfully.", "Attention", MessageBoxButtons.OK, MessageBoxIcon.Information);

                // Refresh the DataGridView to reflect the changes
                LoadAdminList();
            }
            else
            {
                MessageBox.Show("Please select a row to update.");
            }
        }

        private void accommoditionToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Hide();
            menuAccommodation accommodation = new menuAccommodation();
            accommodation.ShowDialog();
            accommodation = null;
            this.Show();
        }

        private void tripsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Hide();
            menuTrips trips = new menuTrips();
            trips.ShowDialog();
            trips = null;
            this.Show();
        }

        private void reservationsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Hide();
            menuReservations reservationsss = new menuReservations();
            reservationsss.ShowDialog();
            reservationsss = null;
            this.Show();
        }

        private void paymentToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Hide();
            menuPayment payment = new menuPayment();
            payment.ShowDialog();
            payment = null;
            this.Show();
        }

        private void reviewsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Hide();
            menuReviews review = new menuReviews();
            review.ShowDialog();
            review = null;
            this.Show();
        }

        private void adminUsers_Load(object sender, EventArgs e)
        {
            LoadAdminList();
        }
    }


}
