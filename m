From: "bunty " <bunty123_4@rediffmail.com>
Subject: unable to call ntohs function in kernel module
Date: 3 Dec 2004 10:20:29 -0000
Message-ID: <20041203102029.23445.qmail@webmail25.rediffmail.com>
Reply-To: "bunty " <bunty123_4@rediffmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="Next_1102069228---0-203.199.83.147-23428"
Cc: netdev@oss.sgi.com
Return-path: <kernelnewbies-bounce@nl.linux.org>
To: kernelnewbies@nl.linux.org
Sender: kernelnewbies-bounce@nl.linux.org
Errors-to: kernelnewbies-bounce@nl.linux.org
List-help: <mailto:ecartis@nl.linux.org?Subject=help>
List-unsubscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=unsubscribe>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=subscribe>
List-owner: <mailto:ecartis-owner@nl.linux.org>
List-post: <mailto:kernelnewbies@nl.linux.org>
List-archive: <http://mail.nl.linux.org/kernelnewbies/>
List-Id: netdev.vger.kernel.org

 This is a multipart mime message


--Next_1102069228---0-203.199.83.147-23428
Content-type: text/plain;
	charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

hello,=0AWhat i observed about noths with respect to Fedora core 1 kernel i=
s that if i write a simple network C program i can call ntohl, ntohs,htonl,=
htons from netinet/in.h but same if i call from kernel module why it gives =
ntohs unresolved symbol error?=0AAlso if try to include netinet/in.h it wil=
l give me errors at compile time.=0A=0Aregards,=0Aparag.=0A
--Next_1102069228---0-203.199.83.147-23428
Content-type: text/html;
	charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<P>=0Ahello,<BR>=0AWhat i observed about noths with respect to Fedora core =
1 kernel is that if i write a simple network C program i can call ntohl, nt=
ohs,htonl,htons from netinet/in.h but same if i call from kernel module why=
 it gives ntohs unresolved symbol error?<BR>=0AAlso if try to include netin=
et/in.h it will give me errors at compile time.<BR>=0A<BR>=0Aregards,<BR>=
=0Aparag.<BR>=0A=0A</P>=0A<br><br>=0A<A target=3D"_blank" HREF=3D"http://cl=
ients.rediff.com/signature/track_sig.asp"><IMG SRC=3D"http://ads.rediff.com=
/RealMedia/ads/adstream_nx.cgi/www.rediffmail.com/inbox.htm@Bottom" BORDER=
=3D0 VSPACE=3D0 HSPACE=3D0></a>=0A
--Next_1102069228---0-203.199.83.147-23428--


--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
FAQ:           http://kernelnewbies.org/faq/
