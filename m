From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/20] drivers/net/wireless/p54: remove depends on
 CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 14:12:52 -0500 (EST)
Message-ID: <20130122.141252.781223481145097577.davem@davemloft.net>
References: <1358879444-25834-17-git-send-email-keescook@chromium.org>
	<201301221937.16916.chunkeey@googlemail.com>
	<CAGXu5jJCQshUntUk7MeZds59B2fa54GnonOz28dM1x2spEEGDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chunkeey@googlemail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linville@tuxdriver.com, kvalo@qca.qualcomm.com
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899Ab3AVTMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 14:12:55 -0500
In-Reply-To: <CAGXu5jJCQshUntUk7MeZds59B2fa54GnonOz28dM1x2spEEGDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Tue, 22 Jan 2013 10:40:12 -0800

> On Tue, Jan 22, 2013 at 10:37 AM, Christian Lamparter
> <chunkeey@googlemail.com> wrote:
>> Aren't these patches going through wireless-next
>> or linux-next?
> 
> They can go however it makes things easiest. Greg has offered to carry
> them in driver-core if Dave doesn't want to carry them in netdev.

Greg can take these:

Acked-by: David S. Miller <davem@davemloft.net>
