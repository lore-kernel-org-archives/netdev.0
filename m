From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH V6 8/8] hvsock: introduce Hyper-V Socket feature
Date: Tue, 26 Jan 2016 11:24:12 +0100
Message-ID: <20160126102412.GA19626@aepfle.de>
References: <1453801515-3501-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: gregkh@linuxfoundation.org, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, apw@canonical.com,
	jasowang@redhat.com, kys@microsoft.com, vkuznets@redhat.com,
	pebolle@tiscali.nl, stefanha@redhat.com, dan.carpenter@oracle.com
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1453801515-3501-1-git-send-email-decui@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, Dexuan Cui wrote:

> +#define AF_MAX		42	/* For now.. */

Maybe net/core/sock.c needs additional strings for the new socket?

Olaf
