From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH v3] xen-apic: Enable on domU as well
Date: Mon, 10 Aug 2015 14:41:59 +0100
Message-ID: <55C8AA27.8090207@citrix.com>
References: <1438879025-27362-1-git-send-email-Jason@zx2c4.com>
 <1439214027-13994-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <stable@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439214027-13994-1-git-send-email-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/08/15 14:40, Jason A. Donenfeld wrote:
> It turns out that domU also requires the Xen APIC driver. Otherwise we
> get stuck in busy loops that never exit, such as in this stack trace:

What's the difference between v3 and v2?

David
