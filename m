From: Andras Kis-Szabo <kisza@securityaudit.hu>
Subject: net/ipv6/exthdrs.c
Date: Tue, 18 Jun 2002 13:51:49 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020618135149.A24751@sch.bme.hu>
References: <Pine.LNX.4.44.0206171314460.2496-300000@lain.perlfu.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0206171314460.2496-300000@lain.perlfu.co.uk>
List-Id: netdev.vger.kernel.org

Hi,

It's just a short question...

Is there any plan to add the ESP header to the ipv6_ext_hdr() function (as a
known header)?
(It requires changes in this file and in the icmp.c at the first round.)

Some user noticed that the Netfilter contains a very similar function, which
knows the ESP.
If this functon remains untouched, I'll add an another one into the Netfilter
code (which can be used at the special matches).

Regards,

	kisza

-- 
    Andras Kis-Szabo       Security Development, Design and Audit
-------------------------/        Zorp, NetFilter and IPv6
 kisza@SecurityAudit.hu /-----Member of the BUTE-MIS-SEARCHlab---------->
