From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Wed, 11 Mar 2015 08:40:34 -0400
Message-ID: <20150311084034.04ce6801@grimm.local.home>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
	<20150311081909.552e2052@grimm.local.home>
	<55003666.3020100@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	netdev@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55003666.3020100@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Mar 2015 08:34:46 -0400
Sasha Levin <sasha.levin@oracle.com> wrote:

> Fair enough. We knew there are existing kmemcheck users, but KASan should be
> superior both in performance and the scope of bugs it finds. It also shouldn't
> impose new limitations beyond requiring gcc 4.9.2+.
>

Ouch! OK, then I can't use it. I'm currently compiling with gcc 4.6.3.

It will be a while before I upgrade my build farm to something newer.

-- Steve
