From: "Chintalapati,Sriram" <Sriram.Chintalapati@wipro.com>
Subject: Help needed: Find Net4 related differences between 2.4.20 and 2.5
	.68 kernel versions
Date: Mon, 5 May 2003 18:21:21 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <2B4B4D30E18DD31180CA00508B0F3002A71D85@wipro-exmbx1.wipro.tcpn.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----------=_3EB6617D.2FD31CBE"
Cc: "'sriramc@wipro.tcpn.com'" <Sriram.Chintalapati@wipro.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------------=_3EB6617D.2FD31CBE
Content-Type: text/plain
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

This mail is probably spam.  The original message has been attached
along with this report, so you can recognize or block similar unwanted
mail in future.  See http://spamassassin.org/tag/ for more details.

Content preview:  This message is in MIME format. Since your mail reader
  does not understand this format, some or all of this message may not be
  legible. ------_=_NextPart_001_01C31305.074BD3C0 Content-Type:
  text/plain [...] 

Content analysis details:   (10.40 points, 5 required)
HTML_MESSAGE       (3.0 points)  BODY: HTML included in message
HTML_40_50         (0.4 points)  BODY: Message is 40% to 50% HTML
MSG_ID_ADDED_BY_MTA_3 (3.0 points)  'Message-Id' was added by a relay (3)
MIME_BOUND_NEXTPART (4.0 points)  Spam tool pattern in MIME boundary

The original message did not contain plain text, and may be unsafe to
open with some email clients; in particular, it may contain a virus,
or confirm that your address can receive spam.  If you wish to view
it, it may be safer to save it to a file and open it with an editor.


------------=_3EB6617D.2FD31CBE
Content-Type: message/rfc822
Content-Description: original message before SpamAssassin
Content-Disposition: attachment
Content-Transfer-Encoding: 8bit

Received: from wiprom2mx1.wipro.com (wiprom2mx1.wipro.com [203.197.164.41])
	by oss.sgi.com (8.12.9/8.12.9) with SMTP id h45D4mFu015591
	for <netdev@oss.sgi.com>; Mon, 5 May 2003 06:04:51 -0700
Received: from m2vwall5.wipro.com (m2vwall5.wipro.com [10.115.50.5])
	by wiprom2mx1.wipro.com (8.11.3/8.11.3) with SMTP id h45D4dN21841
	for <netdev@oss.sgi.com>; Mon, 5 May 2003 18:34:39 +0530 (IST)
Received: from blr-m2-msg.wipro.com ([10.116.50.99]) by blr-m1-bh2.wipro.com with Microsoft SMTPSVC(5.0.2195.5329);
	 Mon, 5 May 2003 18:34:34 +0530
Received: from wipro.tcpn.com ([172.31.41.11]) by blr-m2-msg.wipro.com with Microsoft SMTPSVC(5.0.2195.5329);
	 Mon, 5 May 2003 18:34:34 +0530
Received: from wipro-exconn1.wipro.tcpn.com (wipro-exconn1.wipro.tcpn.com [172.31.41.55])
	by wipro.tcpn.com (8.9.3/8.9.3) with ESMTP id SAA04495;
	Mon, 5 May 2003 18:37:19 +0530 (IST)
Received: by wipro-exconn1.wipro.tcpn.com with Internet Mail Service (5.5.2650.21)
	id <JWHSXJGX>; Mon, 5 May 2003 18:15:34 +0530
Message-ID: <2B4B4D30E18DD31180CA00508B0F3002A71D85@wipro-exmbx1.wipro.tcpn.com>
From: "Chintalapati,Sriram" <Sriram.Chintalapati@wipro.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Cc: "'sriramc@wipro.tcpn.com'" <Sriram.Chintalapati@wipro.com>
Subject: Help needed: Find Net4 related differences between 2.4.20 and 2.5
	.68 kernel versions
Date: Mon, 5 May 2003 18:21:21 +0530 
MIME-Version: 1.0
X-Mailer: Internet Mail Service (5.5.2650.21)
Content-Type: multipart/mixed;
	boundary="----=_NextPartTM-000-36df13d1-7afa-11d7-ba7f-006067005148"
X-OriginalArrivalTime: 05 May 2003 13:04:34.0379 (UTC) FILETIME=[DFE871B0:01C31306]

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------=_NextPartTM-000-36df13d1-7afa-11d7-ba7f-006067005148
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C31305.074BD3C0"

------_=_NextPart_001_01C31305.074BD3C0
Content-Type: text/plain

Hi,
 
I need some guidance regarding finding differences related to Net4 between
2.4.20 and 2.5.68 kernel versions.
Aim is to make a list of code changes that might be needed to use
SOCK_STREAM option for SCTP protocol and any dependent changes. 
Can you please let me know how these differences can be found? Do I need to
look for a list patches present for 2.5 kernel that need to be migrated
back? If so, where can I get list of patches that are needed?
Can you please let me know the best way to proceed for this task?
 
Please let me know if this is not the right place for this question.
 
Please let me know if I need to provide any additional information.
 
Thanks,
Sriram
 

------_=_NextPart_001_01C31305.074BD3C0
Content-Type: text/html

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=us-ascii">
<TITLE>Message</TITLE>

<META content="MSHTML 5.50.4522.1800" name=GENERATOR></HEAD>
<BODY>
<DIV><SPAN class=968160806-05052003><FONT face=Arial 
size=2>Hi,</FONT></SPAN></DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial size=2>I need some guidance 
regarding finding differences related to Net4 between 2.4.20 and 2.5.68 kernel 
versions.</FONT></SPAN></DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial size=2>Aim is to make a 
list of code changes that might be needed to use SOCK_STREAM option for SCTP 
protocol and any dependent changes. </FONT></SPAN></DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial size=2>Can you please let 
me know how&nbsp;these differences can be found? Do I need to look for a list 
patches present for 2.5 kernel that need to be migrated back? If so,&nbsp;where 
can I get list of patches that are needed?</FONT></SPAN></DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial size=2>Can you please let 
me know the best way to proceed for this task?</FONT></SPAN></DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial size=2>Please let me know 
if this is not the right place for this question.</FONT></SPAN></DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial size=2>Please let me know 
if I need to provide any additional information.</FONT></SPAN></DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial 
size=2>Thanks,</FONT></SPAN></DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial 
size=2>Sriram</FONT></SPAN></DIV>
<DIV><SPAN class=968160806-05052003><FONT face=Arial 
size=2></FONT></SPAN>&nbsp;</DIV></BODY></HTML>

------_=_NextPart_001_01C31305.074BD3C0--

------=_NextPartTM-000-36df13d1-7afa-11d7-ba7f-006067005148--


------------=_3EB6617D.2FD31CBE--
