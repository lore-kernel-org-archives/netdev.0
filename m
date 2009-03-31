From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] Add common OF device tree support for MDIO busses
Date: Tue, 31 Mar 2009 14:57:38 -0700 (PDT)
Message-ID: <20090331.145738.36845509.davem@davemloft.net>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Joakim.Tjernlund@transmode.se, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, afleming@freescale.com, olof@lixom.net
To: grant.likely@secretlab.ca
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090331075537.1427.7819.stgit@localhost.localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Grant Likely <grant.likely@secretlab.ca>
Date: Tue, 31 Mar 2009 02:26:43 -0600

> David, as I mentioned below, I'd really like to get the core changes
> (1, 4, 5  6) merged into 2.6.30 (assuming Andy confirms they are okay).

No, sorry.

We could have worked out the interdependencies before the merge window
openned up.  There is no reason this could not have sat in at least
somebody's tree before the merge window started.

It therefore didn't get any -next exposure, so it's unreasonable to
merge this stuff now.
