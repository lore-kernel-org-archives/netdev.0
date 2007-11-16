From: "Jon Nelson" <jnelson@jamponi.net>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Fri, 16 Nov 2007 10:21:25 -0600
Message-ID: <cccedfc60711160821p5f1790eaq8d385e71726cd5a0@mail.gmail.com>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>
	 <20071115082600.GA2366@ff.dom.local>
	 <20071115102005.0cf46f9a@freepuppy.rosehill> <473CD1F6.9030709@o2.pl>
	 <cccedfc60711151842l4aafe0ffo220e84a5e37b6a82@mail.gmail.com>
	 <20071115203508.4ad025f2@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:54835 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbXKPQVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 11:21:30 -0500
Received: by nf-out-0910.google.com with SMTP id g13so865576nfb
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2007 08:21:26 -0800 (PST)
In-Reply-To: <20071115203508.4ad025f2@freepuppy.rosehill>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I get a segmentation fault.

Should this patch be in addition to the one from bug 9382?
http://bugzilla.kernel.org/attachment.cgi?id=13555&action=view

-- 
Jon
