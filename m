From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 2/3] net-next: dsa: add Qualcomm tag RX/TX handler
Date: Wed, 14 Sep 2016 22:29:50 -0700
Message-ID: <5a0ecd9d-d2b8-f62e-fb5a-e0251ce9d7d5@gmail.com>
References: <1473849542-3298-1-git-send-email-john@phrozen.org>
 <1473849542-3298-3-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: John Crispin <john@phrozen.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473849542-3298-3-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/2016 03:39 AM, John Crispin wrote:
> Add support for the 2-bytes Qualcomm tag that gigabit switches such as
> the QCA8337/N might insert when receiving packets, or that we need
> to insert while targeting specific switch ports. The tag is inserted
> directly behind the ethernet header.
> 
> Signed-off-by: John Crispin <john@phrozen.org>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
