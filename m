From: Stefan Schmidt <stefan@datenfreihafen.org>
Subject: Re: [PATCH iproute2] ip: update link types to show 6lowpan and
 ieee802.15.4 monitor
Date: Thu, 1 Dec 2016 22:31:41 +0100
Message-ID: <c088572b-2cab-c32e-76c9-4ffd02942db0@datenfreihafen.org>
References: <1477647723-14641-1-git-send-email-stefan@datenfreihafen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-wpan@vger.kernel.org" <linux-wpan@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lasnet.de ([78.47.171.185]:53029 "EHLO
        proxima.lasnet.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750946AbcLAVbr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 16:31:47 -0500
In-Reply-To: <1477647723-14641-1-git-send-email-stefan@datenfreihafen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 28.10.2016 11:42, Stefan Schmidt wrote:
> Both types have been missing here and thus ip always showed
> only the numbers.
> 
> Based on a suggestion from Alexander Aring.
> 
> Signed-off-by: Stefan Schmidt <stefan@datenfreihafen.org>

Did you somehow mangle this patch manually?

Looking at the patch in your git repo it shows no author name but
instead just my patch was send with git format-patch and git send-email
as usual and shows the right author. Was there something worn on my side
or yours? Just checking to avoid it in the future.

http://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/commit/?id=8ae2c5382bd9d98a8f7ddcb1faad1a978d773909

regards
Stefan Schmidt
