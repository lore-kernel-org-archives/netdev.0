From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: net_device + pci_dev question
Date: Sun, 27 Nov 2005 22:25:13 +0100
Message-ID: <1133126713.2853.45.camel@laptopd505.fenrus.org>
References: <2510370984.20051127205827@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751157AbVK0VZS@vger.kernel.org>
To: Mateusz Berezecki <mateuszb@gmail.com>
In-Reply-To: <2510370984.20051127205827@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2005-11-27 at 20:58 +0100, Mateusz Berezecki wrote:
> Hello List!
> 
> Having only net_device pointer is it possible to retrieve associated pci_dev
> pointer basing on this information only?

what do you need it for?

(and.. what if the nic isn't a pci one?)
