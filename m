From: "David S. Miller" <davem@redhat.com>
Subject: Re: TCP congestion control article
Date: Fri, 25 Jun 2004 09:11:58 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040625091158.2e84ed3a.davem@redhat.com>
References: <20040625123953.1d42b556.buffer@antifork.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "Angelo Dell'Aera" <buffer@antifork.org>
In-Reply-To: <20040625123953.1d42b556.buffer@antifork.org>
List-Id: netdev.vger.kernel.org

On Fri, 25 Jun 2004 12:39:53 +0200
"Angelo Dell'Aera" <buffer@antifork.org> wrote:

> I just want to point out to you a really interesting article published
> by  two  members   of  my  research  group.  The   paper  is  entitled
> "Performance  Evaluation and  Comparison  of Westwood+,  New Reno  and
> Vegas TCP  Congestion Control" and  it aims at evaluating  these three
> algorithms in really different scenarios.

Would be interesting to compare with BITCP which we have enabled
by default now in current 2.6.x kernels.
