From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH][v3][17/21] Add IPoIB
	(IP-over-InfiniBand)driver
Date: Mon, 13 Dec 2004 16:14:54 -0800
Message-ID: <52sm694txd.fsf@topspin.com>
References: <5CE025EE7D88BA4599A2C8FEFCF226F5175B0C@taurus.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Hal Rosenstock" <halr@voltaire.com>
In-Reply-To: <5CE025EE7D88BA4599A2C8FEFCF226F5175B0C@taurus.voltaire.com> (Hal
	Rosenstock's message of "Mon, 13 Dec 2004 22:19:09 +0200")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Hal> The latest I-D is now
    Hal> http://www.ietf.org/internet-drafts/draft-ietf-ipoib-ip-over-infiniband-08.txt

Thanks, I'll correct this.

    Hal> Also, isn't DHCP over IB
    Hal> (http://www.ietf.org/internet-drafts/draft-ietf-ipoib-dhcp-over-infiniband-07.txt)
    Hal> also supported ? If so, is that part of this or some other
    Hal> patch being submitted ?

DHCP should work but I don't think it's a kernel issue (I don't think
kernel DHCP for NFS root over IPoIB will work unfortunately).

 - R.
