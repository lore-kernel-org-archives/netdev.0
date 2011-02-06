From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ServerEngines, benet: Avoid potential null deref in
 be_cmd_get_seeprom_data()
Date: Sat, 05 Feb 2011 17:58:35 -0800 (PST)
Message-ID: <20110205.175835.71108338.davem@davemloft.net>
References: <20110205031828.GA12772@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jj@chaosbits.net,
	linux-kernel@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110205031828.GA12772@akhaparde-VBox>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Fri, 4 Feb 2011 21:18:28 -0600

> [PATCH] ServerEngines, benet: Avoid potential null deref in be_cmd_get_seeprom_data()
> 
> Found by: Jesper Juhl <jj@chaosbits.net>
> 
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Applied, thanks.
