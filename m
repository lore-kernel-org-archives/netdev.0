From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sat, 28 Sep 2002 06:58:22 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209280258.GAA02712@sex.inr.ac.ru>
References: <20020927.193541.89132835.davem@redhat.com>
Mime-Version: 1.0
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20020927.193541.89132835.davem@redhat.com> from "David S. Miller" at Sep 27, 2 07:35:41 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> This only runs at connect time

... and also at ip6_build_xmit(). Connected dgram sockets are marginal.

Alexey
