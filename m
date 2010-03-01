From: "Leslie Rhorer" <lrhorer@satx.rr.com>
Subject: (unknown)
Date: Sun, 28 Feb 2010 23:19:59 -0600
Message-ID: <96.B0.23353.08E4B8B4@cdptpa-omtalb.mail.rr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.121]:46644 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730Ab0CAFUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 00:20:03 -0500
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	I was doing some ping testing today, and I ran across some test in
ping's output I have never noticed before.  Several of the responses
returned by `ping -q -c 50 -i 12 xxxxx` had lines like the following:

rtt min/avg/max/mdev = 501.663/12212.524/60863.587/15003.409 ms, pipe 6

	I searched the web using Google, and I came up with several queries
concerning a response of "pipe n", but none of them were ever answered
specifically.  One did mention something about pinging across a VPN
connection, and I was indeed pinging across an openvpn connection, if that
has any relevance.

	Please respond e-mail direct, if you have an answer.  I haven't
joined the mail list just to get an answer to this one minor question.

