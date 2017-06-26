From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2 2/5] net: add netlink_ext_ack argument to
 rtnl_link_ops.changelink
Date: Sun, 25 Jun 2017 22:03:03 -0600
Message-ID: <98ba5949-08dd-cc26-de3a-c876ad333d11@gmail.com>
References: <cover.1498425679.git.mschiffer@universe-factory.net>
 <5cc33eef7e73931895b806a6151297a4408c4505.1498425679.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        linux-ppp@vger.kernel.org, linux-wpan@vger.kernel.org
To: Matthias Schiffer <mschiffer@universe-factory.net>,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, wg@grandegger.com, mkl@pengutronix.de,
        pablo@netfilter.org, laforge@gnumonks.org, paulus@samba.org,
        jiri@resnulli.us, dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        davem@davemloft.net, stephen@networkplumber.org,
        arvid.brodin@alten.se, alex.aring@gmail.com,
        stefan@osg.samsung.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        johannes@sipsolutions.net
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <5cc33eef7e73931895b806a6151297a4408c4505.1498425679.git.mschiffer@universe-factory.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/25/17 3:56 PM, Matthias Schiffer wrote:
> Add support for extended error reporting.
> 
> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>

Acked-by: David Ahern <dsahern@gmail.com>
