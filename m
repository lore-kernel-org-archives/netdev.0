From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: time for TCP ECN defaulting to on?
Date: Fri, 7 Nov 2008 17:07:01 +0200
Message-ID: <200811071707.02030.remi.denis-courmont@nokia.com>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com> <20081107142950.13906925@lxorguk.ukuu.org.uk> <491454A3.1040802@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Dave Hudson <linux-kernel@blueteddy.net>,
	Ilpo =?iso-8859-1?q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	David Miller <davem@davemloft.net>, daniel.blueman@gmail.com,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-net@vger.kernel.org
To: "ext David Newall" <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:38290 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323AbYKGPHg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 10:07:36 -0500
In-Reply-To: <491454A3.1040802@davidnewall.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 07 November 2008 16:45:55 ext David Newall, you wrote:
> Isn't this a question for the IETF to answer?  Are they saying turn o=
n
> ECN now?

=46or what it's worth, the IESG says RFC3168 is a PROPOSED STANDARD.
This is the "entry-level maturity for the standards track":
(ftp://ftp.rfc-editor.org/in-notes/bcp/bcp9.txt)

   A Proposed Standard specification is generally stable, has resolved
   known design choices, is believed to be well-understood, has receive=
d
   significant community review, and appears to enjoy enough community
   interest to be considered valuable.  However, further experience
   might result in a change or even retraction of the specification
   before it advances.
   (...)
   Implementors should treat Proposed Standards as immature
   specifications.  It is desirable to implement them in order to gain
   experience and to validate, test, and clarify the specification.
   However, since the content of Proposed Standards may be changed if
   problems are found or better solutions are identified, deploying
   implementations of such standards into a disruption-sensitive
   environment is not recommended.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
