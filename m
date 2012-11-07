From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/1] isdn: Make CONFIG_ISDN depend on CONFIG_NETDEVICES
Date: Wed, 7 Nov 2012 15:04:36 +0000
Message-ID: <20121107150436.3d25ee51@pyramind.ukuu.org.uk>
References: <1352282103-13665-1-git-send-email-lee.jones@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: Lee Jones <lee.jones@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352282103-13665-1-git-send-email-lee.jones@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  7 Nov 2012 10:55:03 +0100
Lee Jones <lee.jones@linaro.org> wrote:

> It doesn't make much sense to enable ISDN services if you don't
> intend to connect to a network. 

I would disagree. However what I don't understand and you've not
explained is why the current code is a bug or a problem ?

This seems to be a make-work inconvenience causing patch that serves no
useful purpose ?

Alan
