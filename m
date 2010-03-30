From: Luis de Bethencourt <luisbg@ubuntu.com>
Subject: Re: [PATCH 2/2] ath: fix code readability in regd.c
Date: Tue, 30 Mar 2010 18:08:26 +0100
Message-ID: <506b70dc1003301008r7079b9c7u96249c28d67a5bdd@mail.gmail.com>
References: <1269963873-2070-1-git-send-email-luisbg@ubuntu.com>
	 <20100330165645.GB25095@tux>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linville@tuxdriver.com" <linville@tuxdriver.com>,
	Luis Rodriguez <Luis.Rodriguez@atheros.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:42010 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754754Ab0C3RI3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 13:08:29 -0400
In-Reply-To: <20100330165645.GB25095@tux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 5:56 PM, Luis R. Rodriguez
<lrodriguez@atheros.com> wrote:
> On Tue, Mar 30, 2010 at 08:44:33AM -0700, Luis de Bethencourt wrote:
>> This is a patch to the ath/regd.c file that fixes two code
>> readability issues. A space between to separate two defines
>> and the indentation inside the ath_redg_is_eeprom_valid
>> function.
>
> Acked-by: Luis R. Rodriguez <lrodriguez@atheros.com>
>
> You can drop netdev and linux-kernel from future linux-wireless e-mai=
ls
> like this one.
>
> =A0Luis
>

OK. Will do.

Luis
