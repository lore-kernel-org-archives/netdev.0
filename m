From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH] [TCP]: Reworked recovery's TCPCB_LOST marking
 functions
Date: Tue, 6 Mar 2007 15:02:52 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703061459540.3770@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0703061442440.3770@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1661608255-1173186172=:3770"
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46768 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013AbXCFNCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 08:02:53 -0500
In-Reply-To: <Pine.LNX.4.64.0703061442440.3770@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1661608255-1173186172=:3770
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 6 Mar 2007, Ilpo Järvinen wrote:

> because I tested this one (at least the non-timedout part worked) 

...meant that timedout wasn't that throughoutly tested with such a simple 
testcase I used (only FACK was tested).

--
 i.

---696243703-1661608255-1173186172=:3770--
