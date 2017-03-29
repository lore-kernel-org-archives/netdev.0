From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: veth: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 29 Mar 2017 14:07:51 -0700 (PDT)
Message-ID: <20170329.140751.2131745748060444255.davem@davemloft.net>
References: <1490768661-12467-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucien.xin@gmail.com, jarod@redhat.com, stephen@networkplumber.org,
        dsa@cumulusnetworks.com, aduyck@mirantis.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490768661-12467-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Wed, 29 Mar 2017 08:24:21 +0200

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
> Changelog:
> v2:
> - avoid useless initiazation to zero (thanks Xin Long)

Applied.
