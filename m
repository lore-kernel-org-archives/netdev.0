From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: [PATCH v2 10/27] iwlwifi: move under intel vendor directory
Date: Wed, 18 Nov 2015 23:21:31 +0200
Message-ID: <CANUX_P0TpjGhvvo3EyPqLr6An4ERrgDCTY-suzsdjZY-e_NgcA@mail.gmail.com>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
	<1447857966-19560-11-git-send-email-kvalo@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447857966-19560-11-git-send-email-kvalo@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kalle,

On Wed, Nov 18, 2015 at 4:45 PM, Kalle Valo <kvalo@codeaurora.org> wrote:
>
> Part of reorganising wireless drivers directory and Kconfig.
>

I am sorry but I'd prefer to wait with this. We have a big machinery
of scripts / builds and alike that will break. I did give a heads up a
while ago to the people in charge of these scripts that this change is
on the way, but they are not done yet. I will get back to them and ask
them when we can be ready for such a change and then it'll come from
my tree. I promise to try to make it happen ASAP.
The above is relevant for iwlwifi only. As far as I am concerned, you
can move the iwlwifi and ipw.

Thank you.

> Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
> ---
>  MAINTAINERS                                        |    2 +-
