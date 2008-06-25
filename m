From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/8 v2] netfilter: fix string extension for case insensitive
 pattern matching
Date: Wed, 25 Jun 2008 13:03:38 +0200
Message-ID: <4862260A.9060304@trash.net>
References: <> <1214389505-21405-1-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1214389505-21405-1-git-send-email-joonwpark81@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joonwoo Park wrote:
> The flag XT_STRING_FLAG_IGNORECASE indicates case insensitive string
> matching.
> netfilter can find cmd.exe, Cmd.exe, cMd.exe and etc easily.

I've asked you to provide some more information about this patch:

<quote>
A few words for the changelog why this won't break compatibility
by changing the data structure would be nice, especially
considering CRIS that doesn't perform any padding itself (you
might be lucky though because of aligned attribute, but please
verify that yourself).
</quote>

