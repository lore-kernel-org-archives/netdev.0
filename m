From: BZ Benny <bennybbz@yahoo.fr>
Subject: Adresse Resolution ???
Date: Wed, 9 Mar 2005 17:37:22 +0100 (CET)
Message-ID: <20050309163722.40252.qmail@web26608.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

actually , I understand that when ethernet layer
receives data from IP it checks form MAC address in
ARP table located inthe IP layer.=20

is the ARP table in the IP layer?
if it is, the ethernet layer( the ethernet Driver of
the device) send a request to the IP layer for
corespondance between IP adresse and MAC address.
 when it receives the MAC adresse of the destination
It puts it in the the ethernet header. and send the
packet.

what I wanted to know is how ethernet layer in linux
ask IP layer for the target MAC address?

regards
benny


=09

=09
	=09
D=E9couvrez le nouveau Yahoo! Mail : 250 Mo d'espace de stockage pour vos=
 mails !=20
Cr=E9ez votre Yahoo! Mail sur http://fr.mail.yahoo.com/
