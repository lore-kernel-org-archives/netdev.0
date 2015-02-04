From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: Use static attribute groups
 for sysfs entries
Date: Wed, 4 Feb 2015 13:53:39 +0000
Message-ID: <54D22463.4070703@citrix.com>
References: <1423057135-6939-1-git-send-email-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	<netdev@vger.kernel.org>
To: Takashi Iwai <tiwai@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:4862 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755394AbbBDNxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 08:53:42 -0500
In-Reply-To: <1423057135-6939-1-git-send-email-tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/15 13:38, Takashi Iwai wrote:
> Instead of manual calls of device_create_file() and
> device_remove_files(), assign the static attribute groups to netdev
> groups array.  This simplifies the code and avoids the possible
> races.

Acked-by: David Vrabel <david.vrabel@citrix.com>

David
