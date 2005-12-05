From: Jiri Benc <jbenc@suse.cz>
Subject: Re: Broadcom 43xx first results
Date: Mon, 5 Dec 2005 19:00:38 +0100
Message-ID: <20051205190038.04b7b7c1@griffin.suse.cz>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751402AbVLESAl@vger.kernel.org>
To: mbuesch@freenet.de
In-Reply-To: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 04 Dec 2005 19:50:08 +0100, mbuesch@freenet.de wrote:
> The team is in the progress of writing a SoftwareMAC layer,
> which is needed for the bcm device. The SoftMAC is still very
> incomplete. So do not expect to do any fancy stuff like WPA
> or something line that with it.

Why yet another attempt to write 802.11 stack? Sure, the one currently
in the kernel is unusable and everybody knows about it. But why not to
improve code opensourced by Devicescape some time ago instead of
inventing the wheel again and again? Yes, I know that code is not
perfect and needs a lot of work, but it is the best piece of code we
have available now. And it _does_ support WPA and such - in fact, it is
nearly complete.

Please take a look at http://kernel.org/pub/linux/kernel/people/jbenc/

Thanks,

-- 
Jiri Benc
SUSE Labs
