From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool 5/5] ethtool: Add --version option
Date: Tue, 22 Feb 2011 12:37:08 +0000
Message-ID: <1298378228.2211.472.camel@localhost>
References: <1561212236.5138.1298355384916.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:1721 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab1BVMhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 07:37:12 -0500
In-Reply-To: <1561212236.5138.1298355384916.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-02-21 at 22:16 -0800, Stephen Hemminger wrote:
[...]
> The standard convention is to use -V for short form of version option.

This is not anywhere near standard.

$ cp -V
cp: invalid option -- 'V'
Try `cp --help' for more information.
$ bash -V
bash: -V: invalid option
[...]
$ emacs -V
[opens window]
$ vim -V
chdir(/usr/share/vim)
fchdir() to previous dir
sourcing "$VIM/vimrc"
[...looks like that meant 'verbose'...]

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

