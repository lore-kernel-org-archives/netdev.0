From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: Stability of various TCP protocols [CUBIC, BIC, HTCP, HSTCP,
	STCP]
Date: Thu, 28 Sep 2006 12:58:02 -0400
Message-ID: <00d301c6e31f$4304fed0$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_00D0_01C6E2FD.BB6B6A20"
Cc: netdev@vger.kernel.org
Return-path: <end2end-interest-bounces@postel.org>
To: <end2end-interest@postel.org>
List-Unsubscribe: <http://mailman.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=unsubscribe>
List-Archive: <http://mailman.postel.org/pipermail/end2end-interest>
List-Post: <mailto:end2end-interest@postel.org>
List-Help: <mailto:end2end-interest-request@postel.org?subject=help>
List-Subscribe: <http://mailman.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=subscribe>
Sender: end2end-interest-bounces@postel.org
Errors-To: end2end-interest-bounces@postel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_00D0_01C6E2FD.BB6B6A20
Content-Type: text/plain;
	charset="ks_c_5601-1987"
Content-Transfer-Encoding: quoted-printable

Hi,
I'd like to report on a measurement study regarding the stability of =
various TCP variant protocols. Although we can find quite a bit of work =
on fairness and convergence of protocols (including some theoretical =
studies on the topic as well), there is relatively little work on =
measuring the stability of protocols and its impact on protocol =
performance and overall health of the networks (e.g., the overall queue =
fluctions and link utilization). We have measured the degree of rate =
oscillation and fluctuation of protocols to have some understanding of =
protocol stability.=20
We would like to share our results with you to get some feedback from =
the community.=20

We have some theoretical results and also experimental results. Here is =
the link to the experimental results. You can find links to all of our =
experimental data that include results from several hundred experiments.

http://netsrv.csc.ncsu.edu/convex-ordering/

If you need our report on theoretical results,  we can e-mail you the =
report.
Injong Rhee
------=_NextPart_000_00D0_01C6E2FD.BB6B6A20
Content-Type: text/html;
	charset="ks_c_5601-1987"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dks_c_5601-1987">
<META content=3D"MSHTML 6.00.2900.2963" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>Hi,</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>I'd&nbsp;like to report on&nbsp;a =
measurement=20
study&nbsp;regarding the stability of various TCP variant protocols.=20
Although&nbsp;we can find quite a bit of work&nbsp;on fairness and =
convergence=20
of protocols (including some&nbsp;theoretical studies on the topic as =
well),=20
there is relatively little work on measuring the stability of protocols =
and its=20
impact on protocol performance and overall health of the networks (e.g., =
the=20
overall queue fluctions and link utilization).&nbsp;We=20
have&nbsp;measured&nbsp;the degree of rate oscillation and fluctuation =
of=20
protocols to have some understanding of protocol stability. =
</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>We would like to share our results with =
you to get=20
some feedback from the community. </FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>We have some theoretical results and =
also=20
experimental results. Here is the link to the experimental results. You =
can find=20
links to all of our experimental data that include results from several =
hundred=20
experiments.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><A=20
href=3D"http://netsrv.csc.ncsu.edu/convex-ordering/">http://netsrv.csc.nc=
su.edu/convex-ordering/</A></FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>If you need our report on theoretical=20
results,&nbsp; we can e-mail you the report.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Injong Rhee</FONT></DIV></BODY></HTML>

------=_NextPart_000_00D0_01C6E2FD.BB6B6A20--
