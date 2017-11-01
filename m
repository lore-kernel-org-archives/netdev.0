From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] net: dsa: add port parsing functions
Date: Wed, 01 Nov 2017 11:48:20 +0900 (KST)
Message-ID: <20171101.114820.1147870285228723685.davem@davemloft.net>
References: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027195519.5931-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 27 Oct 2017 15:55:12 -0400

> This patchset adds port parsing functions called early in the new
> bindings parsing stage, which regroup all the fetching of static data
> available at the port level, including the port's type, name and CPU
> master interface.
> 
> This simplifies the rest of the code which does not need to dig into
> device tree or platform data again in order to check a port's type or
> name.

Series applied, thanks Vivien.
