From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2.6.0-test6][X25] timer cleanup
Date: Wed, 1 Oct 2003 15:56:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031001155623.06b89258.akpm@osdl.org>
References: <1065018387.7194.336.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Vinay K Nallamothu <vinay.nallamothu@gsecone.com>
In-Reply-To: <1065018387.7194.336.camel@lima.royalchallenge.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Vinay K Nallamothu <vinay.nallamothu@gsecone.com> wrote:
>
> Replace del_timer, mod_timer sequences with mod_timer.

was this tested?
