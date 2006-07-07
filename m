From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] per-task delay accounting taskstats interface: control
 exit data through cpumasks]
Date: Thu, 6 Jul 2006 23:18:51 -0700
Message-ID: <20060706231851.2f043927.pj@sgi.com>
References: <44ACD7C3.5040008@watson.ibm.com>
	<20060706025633.cd4b1c1d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nagar@watson.ibm.com, jlan@sgi.com, Valdis.Kletnieks@vt.edu,
	balbir@in.ibm.com, csturtiv@sgi.com, linux-kernel@vger.kernel.org,
	hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx2-ext.sgi.com ([192.48.171.19]:60586 "EHLO omx2.sgi.com")
	by vger.kernel.org with ESMTP id S1751013AbWGGGTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 02:19:08 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060706025633.cd4b1c1d.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew wrote:
> Your email client performs space-stuffing.

Shailabh,

Some of us find that it is easier and more reliable to use a special
purpose script to send patches, rather than trying to do so via our
email client.  Even though my email client, Sylpheed, probably sends
patches just fine, I enjoy the convenience of preparing the patches
and mailing instructions in my editor, before sending them off with
such a utility.

One possible such utility is 'sendpatchset', which I maintain:

  http://www.speakeasy.org/~pj99/sgi/sendpatchset

It's a script, with the documentation embedded as the help message.

Especially when sending off multiple patches as a set, it provides
more reliable results than trying to prepare and send multiple such
simultaneous messages from the typical email client.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
