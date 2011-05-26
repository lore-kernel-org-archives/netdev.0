From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/6] unicore32: add pkunity-v3 mac/net driver (umal)
Date: Thu, 26 May 2011 14:43:06 +0200
Message-ID: <201105261443.06896.arnd@arndb.de>
References: <cover.1306408804.git.gxt@mprc.pku.edu.cn> <556924396ee34f4af94a2f03767973f1cec35e22.1306408804.git.gxt@mprc.pku.edu.cn>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	greg@kroah.com, netdev@vger.kernel.org
To: GuanXuetao <gxt@mprc.pku.edu.cn>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <556924396ee34f4af94a2f03767973f1cec35e22.1306408804.git.gxt@mprc.pku.edu.cn>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 26 May 2011, GuanXuetao wrote:
> From: Guan Xuetao <gxt@mprc.pku.edu.cn>
> 
> Signed-off-by: Guan Xuetao <gxt@mprc.pku.edu.cn>

No objections to this driver, just remember that network drivers should
go through the netdev tree, and if it wasn't in there before the merge
window, you missed your chance for this time.
