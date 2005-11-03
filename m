From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PKT_SCHED]: Rework QoS and/or fair queueing configuration
Date: Thu, 3 Nov 2005 02:25:04 -0200
Message-ID: <39e6f6c70511022025x17d14571rf306f2b926a56efb@mail.gmail.com>
References: <Pine.LNX.4.61.0510280902470.6910@yvahk01.tjqt.qr>
	 <20051031102621.GF8009@stusta.de>
	 <20051031132729.GK23537@postel.suug.ch>
	 <20051101141302.GM23537@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: bunk@stusta.de, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030315AbVKCEZG@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20051101141302.GM23537@postel.suug.ch>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/1/05, Thomas Graf <tgraf@suug.ch> wrote:
>
> Make "QoS and/or fair queueing" have its own menu, it's too big to be
> inlined into "Network options". Remove the obsolete NET_QOS option.
> Automatically select NET_CLS if needed. Do the same for NET_ESTIMATOR
> but allow it to be selected manually for statistical purposes. Add
> comments to separate queueing from classification. Fix dependencies
> and ordering of classifiers. Improve descriptions/help texts and
> remove outdated pieces.
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Thanks, applied.
