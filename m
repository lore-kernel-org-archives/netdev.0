From: "Michael B. Trausch" <mike-cRPrJ27hGUicqzYg7KEe8g@public.gmane.org>
Subject: Re: LXC bridged networking issues
Date: Wed, 10 Feb 2010 17:42:47 -0500
Message-ID: <4B733667.80309@trausch.us>
References: <4B732911.7070209@trausch.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B732911.7070209-cRPrJ27hGUicqzYg7KEe8g@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/10/2010 04:45 PM, Michael B. Trausch wrote:
> Insofar as other data, I don't know what else to provide. I am
> completely confused and I haven't the slightest clue how to debug this
> setup. Am I doing something wrong with LXC that OpenVZ or full
> virtualization handles for me? Have I stumbled upon some bug in the
> stack somewhere?

Ahh, nevermind.

It would seem that in this case, the answer is that yours truly here is 
a moron.  I done did screwed up: two of the interfaces had the same MAC 
address.

My apologies for the noise.

	--- Mike

-- 
Michael B. Trausch                    Blog: http://mike.trausch.us/blog/
Tel: (404) 592-5746 x1                            Email: mike-cRPrJ27hGUicqzYg7KEe8g@public.gmane.org
