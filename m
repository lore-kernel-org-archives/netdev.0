From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] (1/4) bridge: use jenkins hash
Date: Thu, 10 Mar 2005 18:49:41 -0800
Message-ID: <20050310184941.21a033bb.davem@davemloft.net>
References: <20050310154429.0f879894@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@osdl.org
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050310154429.0f879894@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Mar 2005 15:44:29 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Replace the existing mac hash in the bridge code with the nice
> inline jenkins hash. This should provide better distribution across
> hash buckets and compiles to code that is similar in complexity.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
