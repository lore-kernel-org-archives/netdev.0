From: Mehulkumar J Patel <mehul.patel@in.ibm.com>
Subject: Re: Linux kernel updates and ip_crossover patch
Date: Mon, 27 Oct 2003 19:54:37 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFFB9A4514.B67F61BB-ON65256DCC.0042B431-65256DCC.004F8B0D@in.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 004F8B0565256DCC_="
Cc: Matthias Fruehauf <mfrueh@suse.de>, olaf@suse.de,
        Anil K Prasad <aprasad@in.ibm.com>,
        Daljeet Maini <mdaljeet@in.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--=_alternative 004F8B0565256DCC_=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi,

We at IBM need IP CROSSOVER module as part of kernel source.

I sent the request to SuSe for the same and they got back to me and their=20
response is in this mail thread below.

Can you please let me know what do you think about IP CROSSOVER feature ?

best regards,
Mehul.
----- Forwarded by Mehulkumar J Patel/India/IBM on 27/10/2003 17:42 -----


Olaf Hering <olh@suse.de>
29/09/2003 16:40

=20
        To:     Kaena Freitas <kaena@us.ibm.com>, Mehulkumar J Patel/India/=
IBM@IBMIN
        cc:     Mehulkumar J Patel/India/IBM@IBMIN, Matthias Fruehauf <mfru=
eh@suse.de>,=20
olaf@suse.de, Anil K Prasad/India/IBM@IBMIN, Daljeet Maini/India/IBM@IBMIN
        Subject:        Re: Linux kernel updates and ip=5Fcrossover patch

=20

 On Wed, Sep 24, Kaena Freitas wrote:

>=20
>=20
>=20
>=20
> Hello Mehul -
>=20
> Sorry it has taken me a while to respond. We do not keep any code in=20
CMVC.
> All code we get from SuSE is on the ftp3 site along with all the source
> RPMs. We do have internel CVS trees, but there is no guarantee that=20
those
> trees are current with the code we get from SuSE which is what your team
> should be testing.
>=20
> As for the htx patch you've provided, I have copied SuSE on this email=20
to
> get their comments if it can be part of their distribution.

Good morning,

did you sent the patch to netdev@oss.sgi.com?
What opinion have the network and iptables maintainers about this feature?


> (See attached file: hxecom=5Fpatch)forgot to attach the patch.
>=20
>=20
> e-mail: mehul.patel@in.ibm.com
> IBM Global Services
> Bangalore, India.
> Tel: 091-80-5094160
>=20
>=20
>=20
> =20
>                       Mehulkumar J  =20
>                       Patel                    To:       Kaena=20
Freitas/Austin/IBM=20
>                                                cc:       Anil K=20
Prasad/India/IBM@IBMIN, Daljeet=20
>                       23/09/2003 18:38          Maini/India/IBM@IBMIN    =

=20
>                       Please respond to        From:     Mehulkumar J=20
Patel/India/IBM@IBMIN=20
>                                                Subject:  Linux kernel=20
updates and ip=5Fcrossover patch=20
> =20
> =20
> =20
>=20
>=20
>=20
> Hi,
>=20
> We are HTX Team.
> We get affected by changes in Linux kernel in a way where we have to=20
update
> our build environment
> continuously. As of now we are doing so manually. But considering the
> effort we are thinking of making
> it automated.
>=20
> Can you please tell us if there is a fixed place from where we can sync
> Linux kernel sources through
> scripts. Or do you put Linux kernel sources in cmvc or any other version
> control system.
>=20
> Also, we have an exerciser named "hxecom" which requires an external=20
patch,
> ip=5Fcrossover for hxecom
>  to work in single system test.
> This patch helps us in sending packets destined to IP address on the=20
same
> machine without looping
> back at IP layer. Packet actually goes out to hardware and thus we are=20
able
> to stress network cards.
> For this patch to work, kernel should have been compiled with netfilter.
> If netfilter is not enabled and ip=5Fcrossover patch is not applied, we=20
end
> up recompiling the whole
> stuff and need to copy kernel and /lib/modules on all the test machines,
> which is bit ugly.
> Can you please include these two request from us in all p-series kernels =

?
>=20
> I am attaching the patch here.
>=20
> best regards,
> Mehul.
> e-mail: mehul.patel@in.ibm.com
> IBM Global Services
> Bangalore, India.
> Tel: 091-80-5094160
>=20
>=20
>=20



--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=DCRNBERG



--=_alternative 004F8B0565256DCC_=
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


<br><font size=3D2 face=3D"sans-serif">Hi,</font>
<br>
<br><font size=3D2 face=3D"sans-serif">We at IBM need IP CROSSOVER module a=
s part of kernel source.</font>
<br>
<br><font size=3D2 face=3D"sans-serif">I sent the request to SuSe for the s=
ame and they got back to me and their response is in this mail thread below=
.</font>
<br>
<br><font size=3D2 face=3D"sans-serif">Can you please let me know what do y=
ou think about IP CROSSOVER feature ?</font>
<br>
<br><font size=3D2 face=3D"sans-serif">best regards,</font>
<br><font size=3D2 face=3D"sans-serif">Mehul.</font>
<br><font size=3D1 color=3D#800080 face=3D"sans-serif">----- Forwarded by M=
ehulkumar J Patel/India/IBM on 27/10/2003 17:42 -----</font>
<br>
<table width=3D100%>
<tr valign=3Dtop>
<td>
<td><font size=3D1 face=3D"sans-serif"><b>Olaf Hering &lt;olh@suse.de&gt;</=
b></font>
<p><font size=3D1 face=3D"sans-serif">29/09/2003 16:40</font>
<br>
<td><font size=3D1 face=3D"Arial">&nbsp; &nbsp; &nbsp; &nbsp; </font>
<br><font size=3D1 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; To: &nbs=
p; &nbsp; &nbsp; &nbsp;Kaena Freitas &lt;kaena@us.ibm.com&gt;, Mehulkumar J=
 Patel/India/IBM@IBMIN</font>
<br><font size=3D1 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; cc: &nbs=
p; &nbsp; &nbsp; &nbsp;Mehulkumar J Patel/India/IBM@IBMIN, Matthias Fruehau=
f &lt;mfrueh@suse.de&gt;, olaf@suse.de, Anil K Prasad/India/IBM@IBMIN, Dalj=
eet Maini/India/IBM@IBMIN</font>
<br><font size=3D1 face=3D"sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; Subject:=
 &nbsp; &nbsp; &nbsp; &nbsp;Re: Linux kernel updates and ip=5Fcrossover pat=
ch</font>
<br>
<br><font size=3D1 face=3D"Arial">&nbsp; &nbsp; &nbsp; &nbsp;</font></table>
<br>
<br><font size=3D2 face=3D"Courier New">&nbsp;On Wed, Sep 24, Kaena Freitas=
 wrote:<br>
<br>
&gt; <br>
&gt; <br>
&gt; <br>
&gt; <br>
&gt; Hello Mehul -<br>
&gt; <br>
&gt; Sorry it has taken me a while to respond. We do not keep any code in C=
MVC.<br>
&gt; All code we get from SuSE is on the ftp3 site along with all the sourc=
e<br>
&gt; RPMs. We do have internel CVS trees, but there is no guarantee that th=
ose<br>
&gt; trees are current with the code we get from SuSE which is what your te=
am<br>
&gt; should be testing.<br>
&gt; <br>
&gt; As for the htx patch you've provided, I have copied SuSE on this email=
 to<br>
&gt; get their comments if it can be part of their distribution.<br>
<br>
Good morning,<br>
<br>
did you sent the patch to netdev@oss.sgi.com?<br>
What opinion have the network and iptables maintainers about this feature?<=
br>
<br>
<br>
&gt; (See attached file: hxecom=5Fpatch)forgot to attach the patch.<br>
&gt; <br>
&gt; <br>
&gt; e-mail: mehul.patel@in.ibm.com<br>
&gt; IBM Global Services<br>
&gt; Bangalore, India.<br>
&gt; Tel: 091-80-5094160<br>
&gt; <br>
&gt; <br>
&gt; <br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nb=
sp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;=
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; Mehulkumar J &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;=
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbs=
p; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &n=
bsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; Patel &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;=
 &nbsp;To: &nbsp; &nbsp; &nbsp; Kaena Freitas/Austin/IBM &nbsp; &nbsp; &nbs=
p; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &n=
bsp; &nbsp; &nbsp; &nbsp;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
; &nbsp; &nbsp; &nbsp;cc: &nbsp; &nbsp; &nbsp; Anil K Prasad/India/IBM@IBMI=
N, Daljeet &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; 23/09/2003 18:38 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Maini/India/IBM@I=
BMIN &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
; &nbsp; &nbsp;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; Please respond to &nbsp; &nbsp; &nbsp; &nbsp;From: &nbsp; &nbsp; Meh=
ulkumar J Patel/India/IBM@IBMIN &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
; &nbsp; &nbsp; &nbsp;Subject: &nbsp;Linux kernel updates and ip=5Fcrossove=
r patch &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nb=
sp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;=
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nb=
sp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;=
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nb=
sp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &=
nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;=
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br>
&gt; <br>
&gt; <br>
&gt; <br>
&gt; Hi,<br>
&gt; <br>
&gt; We are HTX Team.<br>
&gt; We get affected by changes in Linux kernel in a way where we have to u=
pdate<br>
&gt; our build environment<br>
&gt; continuously. As of now we are doing so manually. But considering the<=
br>
&gt; effort we are thinking of making<br>
&gt; it automated.<br>
&gt; <br>
&gt; Can you please tell us if there is a fixed place from where we can syn=
c<br>
&gt; Linux kernel sources through<br>
&gt; scripts. Or do you put Linux kernel sources in cmvc or any other versi=
on<br>
&gt; control system.<br>
&gt; <br>
&gt; Also, we have an exerciser named &quot;hxecom&quot; which requires an =
external patch,<br>
&gt; ip=5Fcrossover for hxecom<br>
&gt; &nbsp;to work in single system test.<br>
&gt; This patch helps us in sending packets destined to IP address on the s=
ame<br>
&gt; machine without looping<br>
&gt; back at IP layer. Packet actually goes out to hardware and thus we are=
 able<br>
&gt; to stress network cards.<br>
&gt; For this patch to work, kernel should have been compiled with netfilte=
r.<br>
&gt; If netfilter is not enabled and ip=5Fcrossover patch is not applied, w=
e end<br>
&gt; up recompiling the whole<br>
&gt; stuff and need to copy kernel and /lib/modules on all the test machine=
s,<br>
&gt; which is bit ugly.<br>
&gt; Can you please include these two request from us in all p-series kerne=
ls ?<br>
&gt; <br>
&gt; I am attaching the patch here.<br>
&gt; <br>
&gt; best regards,<br>
&gt; Mehul.<br>
&gt; e-mail: mehul.patel@in.ibm.com<br>
&gt; IBM Global Services<br>
&gt; Bangalore, India.<br>
&gt; Tel: 091-80-5094160<br>
&gt; <br>
&gt; <br>
&gt; <br>
<br>
<br>
<br>
-- <br>
USB is for mice, FireWire is for men!<br>
<br>
sUse lINUX ag, n=DCRNBERG<br>
</font>
<br>
<br>
--=_alternative 004F8B0565256DCC_=--
