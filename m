From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/8 v3] netfilter: fix string extension for case insensitive
 pattern matching
Date: Mon, 07 Jul 2008 13:27:39 +0200
Message-ID: <4871FDAB.1080607@trash.net>
References: <> <1215389669-19905-1-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1215389669-19905-1-git-send-email-joonwpark81@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joonwoo Park wrote:
> The flag XT_STRING_FLAG_IGNORECASE indicates case insensitive string
> matching.
> netfilter can find cmd.exe, Cmd.exe, cMd.exe and etc easily.
> 
> A new revision 1 was added, in the meantime invert of xt_string_info was
> moved into flags as a flag.
> If revision is 1, The flag XT_STRING_FLAG_INVERT indicates invert
> matching.

Applied, thanks.

