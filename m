From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 2/3] net-next: dsa: add Qualcomm tag RX/TX handler
Date: Thu, 15 Sep 2016 02:24:28 +0200
Message-ID: <20160915002428.GB29110@lunn.ch>
References: <1473849542-3298-1-git-send-email-john@phrozen.org>
 <1473849542-3298-3-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473849542-3298-3-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 12:39:01PM +0200, John Crispin wrote:
> Add support for the 2-bytes Qualcomm tag that gigabit switches such as
> the QCA8337/N might insert when receiving packets, or that we need
> to insert while targeting specific switch ports. The tag is inserted
> directly behind the ethernet header.
> 
> Signed-off-by: John Crispin <john@phrozen.org>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
