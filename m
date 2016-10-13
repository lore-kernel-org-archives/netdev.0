From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH] iwlwifi: pcie: fix SPLC structure parsing
Date: Thu, 13 Oct 2016 13:27:55 +0200
Message-ID: <1476358075.1999.5.camel@tiscali.nl>
References: <1476349269.3880.18.camel@coelho.fi>
         <20161013102155.14547-1-luca@coelho.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxwifi@intel.com, emmanuel.grumbach@intel.com,
        johannes@sipsolutions.net, kvalo@codeaurora.org,
        oren.givon@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Luca Coelho <luca@coelho.fi>, linux-wireless@vger.kernel.org,
        chris@rorvick.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161013102155.14547-1-luca@coelho.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luca,

On Thu, 2016-10-13 at 13:21 +0300, Luca Coelho wrote:
> Could you please give this a spin? I have tested it with some handmade
> ACPI tables in QEMU and it seems to work fine now.

Tested-by: Paul Bolle <pebolle@tiscali.nl>

Not that this test was worth a lot: it builds cleanly (on top of
4.8.1), the error at boot is gone, obviously, and wifi still works (as
you're reading a message that was sent out over wifi). And I haven't
even tested this on another machine than my XPS 13 (9350).

Thanks!


Paul Bolle
