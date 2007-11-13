From: "Bartlomiej Zolnierkiewicz" <bzolnier@gmail.com>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 16:21:06 +0100
Message-ID: <58cb370e0711130721g49a28666u6d315c1412b0c855@mail.gmail.com>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com>
	 <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Natalie Protasevich" <protasnb@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:40966 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944AbXKMPVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 10:21:08 -0500
Received: by wr-out-0506.google.com with SMTP id 36so983896wra
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 07:21:07 -0800 (PST)
In-Reply-To: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Nov 13, 2007 12:15 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon, 12 Nov 2007 22:42:32 -0800 "Natalie Protasevich" <protasnb@gmail.com> wrote:
>
> > This is the listing of the open bugs that are relatively new, around
> > 2.6.22 and up. They are vaguely classified by specific area.
> > (not a full list, there are more :)

[...]

> > IDE/SATA=========================================================

[...]

> > DVD-RAM umount and disk free bug
> > http://bugzilla.kernel.org/show_bug.cgi?id=9265
> > Kernel: 2.6.15  (asked to try current kernel)
>
> No response from developers

Bug was filled under IO/Storage-Other so is it assigned to
<other_other@kernel-bugs.osdl.org>.

Could be a FS problem as well but it is the best to wait for
confirmation with 2.6.23 before proceeding further...
