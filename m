From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: cx89x0: move attribute declaration before
 struct keyword
Date: Tue, 18 Apr 2017 16:00:46 -0400 (EDT)
Message-ID: <20170418.160046.2007615902301910021.davem@davemloft.net>
References: <20170417205434.12663-1-stefan@agner.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shc_work@mail.ru, jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: stefan@agner.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170417205434.12663-1-stefan@agner.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Agner <stefan@agner.ch>
Date: Mon, 17 Apr 2017 13:54:34 -0700

> The attribute declaration is typically before the definition. Move
> the __maybe_unused attribute declaration before the struct keyword.
> 
> Signed-off-by: Stefan Agner <stefan@agner.ch>
> ---
> Changes in v2:
> - Move __maybe_unused after the complete type

Applied to net-next, thank you.
