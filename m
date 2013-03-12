From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ethernet: amd: use PTR_RET instead of IS_ERR + PTR_ERR
Date: Tue, 12 Mar 2013 10:44:47 +0100
Message-ID: <CAMuHMdWDiWoyhufMrtQzwuB93dX6ydRC+y8dS+_8Y4qGPHQcMg@mail.gmail.com>
References: <1363074487-21248-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, joe@perches.com,
	dhowells@redhat.com, linux-kernel@vger.kernel.org
To: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363074487-21248-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 12, 2013 at 8:48 AM, Silviu-Mihai Popescu
<silviupopescu1990@gmail.com> wrote:
> This uses PTR_RET instead of IS_ERR and PTR_ERR in order to increase
> readability.
>
> Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>

Acked-by: <Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
