From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] phy: micrel.c: Enable ksz9031 energy-detect power-down
 mode
Date: Tue, 4 Oct 2016 04:09:49 -0700
Message-ID: <4363b560-b782-03a4-1ec6-1d1f51a303ff@gmail.com>
References: <1475499870-11465-1-git-send-email-mike.looijmans@topic.nl>
 <1475560324-23346-1-git-send-email-mike.looijmans@topic.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Mike Looijmans <mike.looijmans@topic.nl>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475560324-23346-1-git-send-email-mike.looijmans@topic.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 10/03/2016 10:52 PM, Mike Looijmans wrote:
> Set bit 0 in register 1C.23 to enable the EDPD feature of the
> KSZ9031 PHY. This reduces power consumption when the link is
> down.
> 
> Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com
-- 
Florian
