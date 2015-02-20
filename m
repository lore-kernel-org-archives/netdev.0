From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH] pppoe: Use workqueue to die properly when a PADT is
 received
Date: Fri, 20 Feb 2015 14:25:39 +0100
Message-ID: <20150220142539.21186y3dd8fwgamr@berry.schulz.ip-v6.eu>
References: <1424381068-22252-1-git-send-email-simon@farnz.org.uk>
 <3411251.Z29qxOyJF6@f19simon>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	mostrows@gmail.com, linux-ppp@vger.kernel.org
To: Simon Farnsworth <simon@farnz.org.uk>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <3411251.Z29qxOyJF6@f19simon>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc: linux-ppp@vger.kernel.org, mostrows@gmail.com)

Hello!

Simon Farnsworth schrieb am Fri, 20 Feb 2015 11:17:26 +0000:

> Michal's e-mail as listed in MAINTAINERS is bouncing (he's listed as PPPoE
> maintainer).

I once had the same problem. I finally used mostrows@gmail.com, found  
elsewhere (see e.g. http://patchwork.ozlabs.org/patch/36932/).


Regards,
-- 
Christoph Schulz

