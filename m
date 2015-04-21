From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH 1/3] net/dsa: Refactor dsa_probe()
Date: Tue, 21 Apr 2015 09:58:46 -0700
Message-ID: <553681C6.6030509@gmail.com>
References: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz> <1429622791-7195-2-git-send-email-kaisrja1@fel.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: sojkam1@fel.cvut.cz, tkonecny@retia.cz, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Kaisrlik <ja.kaisrlik@gmail.com>
To: Jan Kaisrlik <kaisrja1@fel.cvut.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429622791-7195-2-git-send-email-kaisrja1@fel.cvut.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/04/15 06:26, Jan Kaisrlik wrote:
> From: Jan Kaisrlik <ja.kaisrlik@gmail.com>
> 
> This patch refactors dsa_probe in order to simplify code in the patch 2/3.

It does not look like you are working on the latest net-next tree, that
part of the code has already been refactored to have separate helper
functions such as dsa_setup_dst(), dsa_switch_setup() and
dsa_switch_setup_one().
-- 
Florian
