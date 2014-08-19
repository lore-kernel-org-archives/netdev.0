From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] drivers: net: ethernet: intel: e1000: e1000_ethertoo.c
 coding style fixes
Date: Tue, 19 Aug 2014 11:04:09 -0500
Message-ID: <CAL3LdT7+5FFbP5Rf1MoY2GJ9cQ0LJnecQb66ZA2ofwD28vy1jw@mail.gmail.com>
References: <1408393263-18027-1-git-send-email-cristos@vipserv.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Perches <joe@perches.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408393263-18027-1-git-send-email-cristos@vipserv.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 18, 2014 at 3:21 PM, Krzysztof Majzerowicz-Jaszcz
<cristos@vipserv.org> wrote:
> Fixed many errors/warnings and checks in e1000_ethtool.c reported by checkpatch.pl
> Suggestions from Joe Perches and Alexander Duyck applied as well
>
> Signed-off-by: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 155 ++++++++++++-----------
>  1 file changed, 79 insertions(+), 76 deletions(-)
>

Thanks Krzysztof, I will add your patch to my queue and I can fix up
the patch title for you. :-)
