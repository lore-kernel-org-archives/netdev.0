From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [patch 2.6.11] bonding: avoid tx balance for IGMP (alb/tlb mode)
Date: Wed, 16 Mar 2005 01:59:08 -0800
Message-ID: <OFDEDA7621.E9BF197B-ON88256FC6.003688EE-88256FC6.0036DABF@us.ibm.com>
References: <200503160103.j2G132YO016999@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: bonding-devel@lists.sourceforge.net, ctindel@users.sourceforge.net,
        jgarzik@pobox.com, linux-kernel@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com, Rick Jones <rick.jones2@hp.com>
In-Reply-To: <200503160103.j2G132YO016999@death.nxdomain.ibm.com>
To: fubar@us.ibm.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I didn't look to see if there's a case in that switch for IPv6, but MLD 
will have
the same issue with switches, and probably needs a similar exception.

                                        +-DLS
