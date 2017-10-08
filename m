From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 1/9] net: dsa: mv88e6xxx: add accessors for
 PTP/TAI registers
Date: Sun, 8 Oct 2017 10:32:08 -0400
Message-ID: <20171008143207.ol5zpjtvj4vqbjf5@localhost>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-2-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506612341-18061-2-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 10:25:33AM -0500, Brandon Streiff wrote:
> This patch implements support for accessing PTP/TAI registers through

To avoid confusion, it would be helpful to mention what TAI stands for
here and also in the source code comments!

Thanks,
Richard
