From: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
Subject: Re: [PATCH v2] drivers: net: ethernet: intel: e1000: e1000_ethertoo.c
 coding style fixes
Date: Tue, 19 Aug 2014 19:33:56 +0200
Message-ID: <53F38A84.3070702@vipserv.org>
References: <1408393263-18027-1-git-send-email-cristos@vipserv.org> <CAL3LdT7+5FFbP5Rf1MoY2GJ9cQ0LJnecQb66ZA2ofwD28vy1jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sv1-2.x14.eu ([144.76.176.218]:50745 "EHLO sv1-2.x14.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753353AbaHSReD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2014 13:34:03 -0400
In-Reply-To: <CAL3LdT7+5FFbP5Rf1MoY2GJ9cQ0LJnecQb66ZA2ofwD28vy1jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/08/14 18:04, Jeff Kirsher wrote:
> On Mon, Aug 18, 2014 at 3:21 PM, Krzysztof Majzerowicz-Jaszcz
> <cristos@vipserv.org> wrote:
>> Fixed many errors/warnings and checks in e1000_ethtool.c reported by checkpatch.pl
>> Suggestions from Joe Perches and Alexander Duyck applied as well
>>
>> Signed-off-by: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
>> ---
>>  drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 155 ++++++++++++-----------
>>  1 file changed, 79 insertions(+), 76 deletions(-)
>>
> 
> Thanks Krzysztof, I will add your patch to my queue and I can fix up
> the patch title for you. :-)
>

Thank you :). Sorry for that patch title - I guess that 'first pancake is always spoiled'.
Nonetheless, that makes my first successful contribution to the kernel <yay> ;)
