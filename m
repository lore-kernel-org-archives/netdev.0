From: Chris Rankin <rankincj@yahoo.com>
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in 2.6.36.3
Date: Thu, 13 Jan 2011 01:24:53 -0800 (PST)
Message-ID: <945863.60555.qm@web121706.mail.ne1.yahoo.com>
References: <1294909556.3570.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: JesseBrandeburg <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Tushar NDave <tushar.n.dave@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeffrey TKirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web121706.mail.ne1.yahoo.com ([98.138.90.127]:34739 "HELO
	web121706.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932610Ab1AMJYy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 04:24:54 -0500
In-Reply-To: <1294909556.3570.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- On Thu, 13/1/11, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> If you care of performance, dont unload/reload your driver
> all the time, and dont use modules (this matter on old hardware because
> of TLB misses)

As long as I can route the full bandwidth of my ADSLv2 connection then it's fine.

Cheers,
Chris



      
