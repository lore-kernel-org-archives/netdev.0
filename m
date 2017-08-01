From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] netvsc: transparent SR-IOV VF support
Date: Tue, 01 Aug 2017 16:13:55 -0700 (PDT)
Message-ID: <20170801.161355.1491313921797695642.davem@davemloft.net>
References: <20170731234524.30326-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        corbet@lwn.net, devel@linuxdriverproject.org,
        linux-doc@vger.kernel.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170731234524.30326-1-sthemmin@microsoft.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 31 Jul 2017 16:45:21 -0700

> This patch set changes how SR-IOV Virtual Function devices are managed
> in the Hyper-V network driver. It was part of earlier bundle, but
> is now updated.

I think you need to do a rebase.  I just merged net into net-next and
this created some conflicts.
