From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSec] connect: Resource temporarily unavailable
Date: Tue, 24 Feb 2004 10:10:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040224101055.4f66ecff.davem@redhat.com>
References: <1077630520.799.7.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <1077630520.799.7.camel@teapot.felipe-alfaro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 Feb 2004 14:48:41 +0100
Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> wrote:

> connect: Resource temporarily unavailable

Known behavior, and it's unlikely to be changing soon as doing the correct
thing here requires a lot of work.
