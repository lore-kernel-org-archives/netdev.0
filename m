From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] cdc_ncm: flag the u-blox TOBY-L4 as wwan
Date: Mon, 28 Aug 2017 11:25:37 -0700 (PDT)
Message-ID: <20170828.112537.478172702651330119.davem@davemloft.net>
References: <20170825125946.12812-1-aleksander@aleksander.es>
        <20170825133916.13948-1-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, stefano.godeas@u-blox.com,
        marco.demarco@u-blox.com, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org
To: aleksander@aleksander.es
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825133916.13948-1-aleksander@aleksander.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aleksander Morgado <aleksander@aleksander.es>
Date: Fri, 25 Aug 2017 15:39:16 +0200

> The u-blox TOBY-L4 is a LTE Advanced (Cat 6) module with HSPA+ and 2G
> fallback.
> 
> Unlike the TOBY-L2, this module has one single USB layout and exposes
> several TTYs for control and a NCM interface for data. Connecting this
> module may be done just by activating the desired PDP context with
> 'AT+CGACT=1,<cid>' and then running DHCP on the NCM interface.
> 
> Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>

Applied.
